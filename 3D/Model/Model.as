#include "ModelSegment.as"
#include "Interpolation.as"
#include "CMatrix.as"
#include "Animation.as"

shared class Model
{
	float scale = 1.0f;

	private CMatrix matrix;
	private ModelSegment@ rootSegment;
	private ModelAnimation@ animation;

	Model(ModelSegment@ rootSegment, float scale)
	{
		@this.rootSegment = rootSegment;
		this.scale = scale;
	}

	void SetAnimation(ModelAnimation@ animation)
	{
		@this.animation = animation;
	}

	void Render()
	{
		if (animation !is null)
		{
			float t = (Interpolation::getGameTime() / getTicksASecond()) % 1.0f;
			animation.Animate(t);
		}

		CMatrix scaleMatrix;
		scaleMatrix.SetScale(scale);
		matrix *= scaleMatrix;

		rootSegment.Render(matrix, Interpolation::getFrameTime());
	}
}